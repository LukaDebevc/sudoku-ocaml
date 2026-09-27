# Reševalnik sudokujev v OCamlu

Domača naloga pri predmetu Programiranje 1 (FMF, Univerza v Ljubljani), napisana januarja 2023.
Ogrodje (`main.ml` in večino `model.ml`) so pripravili izvajalci predmeta, moja sta `solver.ml` in manjkajoče funkcije v `model.ml`. Pri merjenju hitrosti na predmetu je bila rešitev `dir2` najhitrejša med vsemi oddanimi – v povprečju okoli 7-krat hitrejša od naslednje.

Obe različici rešujeta le običajne sudokuje 9×9. Poleg tega `dir2` predpostavlja, da rešitev obstaja (če ne obstaja, je obnašanje nedefinirano).

## Hitrost

100 običajnih sudokujev iz nabora predmeta, prevedeno z `ocamlopt`, AMD Ryzen 5 5500 (izmerjeno 2026):

| Različica | Pravilno rešenih | Skupni čas | Mediana na sudoku |
|---|---|---|---|
| `dir1` | 100/100 | 12,5 ms | 75 µs |
| `dir2` | 100/100 | 1,9 ms | 12 µs |

## `dir1`: rekurzija s števci

- Stanje je tabela dimenzij 9×9×10. Za celico `(i, j)` in števko `k` hrani, v koliko od treh skupin (vrstica, stolpec, blok 3×3) je `k` še prosta, `k` je kandidat natanko tedaj, ko je vrednost enaka 3. Na indeksu 0 je število veljavnih kandidatov celice.
- Na vsakem koraku poišče prazno celico z najmanj kandidati in rekurzivno poskusi vsakega od njih.
- Ob vpisu števke se posodobijo števci v vrstici, stolpcu in preostalih štirih celicah pripadajočega bloka 3×3 (te so vnaprej izračunane). Če katerakoli celica ostane brez kandidatov, se veja takoj opusti.
- Ob vračanju (backtracking) se spremembe razveljavijo, zato se mreža nikoli ne kopira.

## `dir2`: bitne maske, brez rekurzije

- Za vsako vrstico, stolpec in blok 3×3 se vzdržuje bitna maska prostih števk. Kandidati celice so `vrstica & stolpec & blok`, vpis ali izbris števke pa obsega tri bitne operacije (`AND` / `OR`).
- Število kandidatov, najmanjša števka in maska brez najmanjše števke se berejo iz vnaprej izračunanih tabel (1024 vnosov), zato med reševanjem ni zank po števkah.
- Glavna zanka teče, dokler niso zapolnjene vse celice. Znotraj nje druga zanka pregleduje prazna polja: celico z enim samim kandidatom takoj izpolni in pregled ponovi, sicer si zabeleži celico z najmanj kandidati.
- Na celici z najmanj kandidati se izvede razvejitev: vpiše se najnižji kandidat, preostali pa se shranijo na sklad. Rekurzije ni, vse poteze (tudi vsiljene) se beležijo na istem skladu.
- Če celica ostane brez kandidatov, se s sklada odstranjujejo poteze do prve celice s še neporabljenim kandidatom.
- Vse tabele so alocirane enkrat na začetku, mreža se med izvajanjem ne kopira.

## Uporaba

Prevod in zagon:

```bash
cd dir2
ocamlopt model.ml solver.ml main.ml -o sudoku
./sudoku pot/do/sudoku.sdk
