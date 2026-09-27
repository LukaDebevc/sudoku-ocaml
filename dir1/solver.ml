type grid = int option array array
type lzk = int * int
type resevalno_ogrodje = int array array array

let levi_zgornji_kot n : lzk = (3 * (n / 3),3 * (n mod 3))

let row (sudoku : grid) n =
  let vrstica = Array.make 10 1 in
  for i = 0 to 8 do
    match sudoku.(n).(i) with
    | None -> ()
    | Some x -> (vrstica.(x) <- 0);
  done;
  vrstica

let column (sudoku : grid) n =
let stolpec = Array.make 10 1 in
for i = 0 to 8 do
  match sudoku.(i).(n) with
  | None -> ()
  | Some x -> (stolpec.(x) <- 0);
done;
stolpec

let box (sudoku : grid) (a, b : lzk) : int array =
let skatla = Array.make 10 1 in
for i = 0 to 2 do
  for j = 0 to 2 do
    match sudoku.(a + i).(b + j) with
      | None -> ()
      | Some x -> (skatla.(x) <- 0);
    done;
  done;
  skatla

let konstruiraj_sg (sudoku : grid) : resevalno_ogrodje =
  let super_grid = Array.make 9 (Array.make_matrix 9 10 0) in
  for i = 0 to 8 do super_grid.(i) <- Array.make_matrix 9 10 0 done;
  for i = 0 to 8 do
    let vrstica = row sudoku i in
    let stolpec = column sudoku i in
    for j = 0 to 8 do
      for k = 1 to 9 do
      super_grid.(i).(j).(k) <- vrstica.(k) + super_grid.(i).(j).(k);
      super_grid.(j).(i).(k) <- stolpec.(k) + super_grid.(j).(i).(k);
      done;
    done;

    let a, b = levi_zgornji_kot i in
    let skatla = box sudoku (a, b) in
    for j = 0 to 2 do
      for k = 0 to 2 do
        for l = 1 to 9 do
          super_grid.(a + j).(b + k).(l) <- skatla.(l) + super_grid.(a + j).(b + k).(l)
        done;
      done;
    done;
  done;
  for i = 0 to 8 do
    for j = 0 to 8 do
      super_grid.(i).(j).(0) <- Array.fold_left (fun acc x -> if x = 3 then acc + 1 else acc) 0 super_grid.(i).(j)
    done;
  done;
  super_grid

let find_min (sudoku : grid) (super_grid : resevalno_ogrodje) =
  let min = ref 81 in
  let koordinate = ref (-1, -1) in
  for i = 0 to 8 do
    for j = 0 to 8 do
      match sudoku.(i).(j) with
      | Some x -> ()
      | None -> (if super_grid.(i).(j).(0) < !min then (
        min := super_grid.(i).(j).(0);
        koordinate := (i, j))
        )
    done;
  done;
  let (a, b) = !koordinate in
  if a > -1 then
    (
  let arr = Array.make super_grid.(a).(b).(0) 0 in
  let index = ref 0 in
  for i = 1 to 9 do
    if super_grid.(a).(b).(i) = 3 then (
      arr.(!index) <- i ; index := 1 + !index);
    done;
    (!koordinate, arr))
  else (-1, -1), [|0|]

let levi_zgornji_kot_odseka m n = (3 * (m / 3), 3 * (n / 3))

let produkt_seznamov (arr1 : int array) (arr2 : int array) =
  let produkt = Array.make (Array.length arr1 * Array.length arr2) (0, 0) in
  for i = 0 to Array.length arr1 - 1 do
    for j = 0 to Array.length arr2 - 1 do
        produkt.(i * Array.length arr2 + j) <- (arr1.(i), arr2.(j))
    done;
  done; produkt

let nepokriti_v_skatli m n =
  let (a, b) = levi_zgornji_kot_odseka m n in
  let arr1 = Array.make 2 0 in
  for i = a to a + 2 do
    if i < m then arr1.(i - a) <- i else
      if i > m then arr1.(i - a - 1) <- i
      done;

  let arr2 = Array.make 2 0 in
    for i = b to b + 2 do
    if i < n then arr2.(i - b) <- i else
      if i > n then arr2.(i - b - 1) <- i
      done;
  produkt_seznamov arr1 arr2

let koti_v_skatli =
  let matrika = Array.make_matrix 9 9 [|(1, 1)|] in
  for i = 0 to 8 do
    for j = 0 to 8 do
      matrika.(i).(j) <- nepokriti_v_skatli i j;
    done;
  done;
  matrika

let popravi (sudoku : grid) (super_grid : resevalno_ogrodje) koti (a, b, c : int * int * int) =
  sudoku.(a).(b) <- Some c;
  let korektno = ref true in
  for i = 0 to 8 do

    if sudoku.(i).(b) = None then (
    if super_grid.(i).(b).(c) = 3 then (
      super_grid.(i).(b).(0) <- super_grid.(i).(b).(0) - 1;
      if super_grid.(i).(b).(0) = 0 then korektno := false);
    super_grid.(i).(b).(c) <- super_grid.(i).(b).(c) - 1);

    if sudoku.(a).(i) = None then (
    if super_grid.(a).(i).(c) = 3 then (
      super_grid.(a).(i).(0) <- super_grid.(a).(i).(0) - 1;
      if super_grid.(a).(i).(0) = 0 then korektno := false);
    super_grid.(a).(i).(c) <- super_grid.(a).(i).(c) - 1);
  done;
  for i = 0 to 3 do
    let (m, n) = (koti.(a).(b).(i) : int * int) in
    if sudoku.(m).(n) = None then (
    if super_grid.(m).(n).(c) = 3 then (
        super_grid.(m).(n).(0) <- super_grid.(m).(n).(0) - 1;
        if super_grid.(m).(n).(0) = 0 then korektno := false);
      super_grid.(m).(n).(c) <- super_grid.(m).(n).(c) - 1);
  done;
  !korektno

let odpravi (sudoku : grid) (super_grid : resevalno_ogrodje) koti (a, b, c : int * int * int) =
  for i = 0 to 8 do
    if sudoku.(i).(b) = None then (
    super_grid.(i).(b).(c) <- super_grid.(i).(b).(c) + 1;
    if super_grid.(i).(b).(c) = 3 then (
      super_grid.(i).(b).(0) <- super_grid.(i).(b).(0) + 1));

    if sudoku.(a).(i) = None then (
    super_grid.(a).(i).(c) <- super_grid.(a).(i).(c) + 1;
    if super_grid.(a).(i).(c) = 3 then (
      super_grid.(a).(i).(0) <- super_grid.(a).(i).(0) + 1));
  done;
  for i = 0 to 3 do
    let (m, n) = (koti.(a).(b).(i) : int * int) in
    if sudoku.(m).(n) = None then (
    super_grid.(m).(n).(c) <- super_grid.(m).(n).(c) + 1;
    if super_grid.(m).(n).(c) = 3 then (
        super_grid.(m).(n).(0) <- super_grid.(m).(n).(0) + 1));
  done; sudoku.(a).(b) <- None; ()

exception Resitev
let rec rekurzija (sudoku : grid) (super_grid : resevalno_ogrodje) (koti : (int * int) array array array) =
  let reseno = ref false in
  let (a, b), vrednost = find_min sudoku super_grid in (
  try
  if a = -1 then (reseno:= true; raise Resitev
    );
  for i = 0 to Array.length vrednost - 1 do
    let korektno = popravi sudoku super_grid koti (a, b, vrednost.(i)) in
    if korektno then (
      let odgovor = rekurzija sudoku super_grid koti in
    if odgovor then (reseno:= true; raise Resitev);
    );
    odpravi sudoku super_grid koti (a, b, vrednost.(i));
  done;
with | Resitev -> ());
!reseno

let pretvori_v_resitev (sudoku : grid) bool_ : int array array option =
  if not bool_ then None else (
  let resitev = Array.make_matrix 9 9 0 in
  for i = 0 to 8 do
    for j = 0 to 8 do
      resitev.(i).(j) <- (
      match sudoku.(i).(j) with
      | Some x -> x
      | None -> failwith "napaka pri resitvi"
      );
    done; done; Some resitev
  )

let resi (sudoku : grid) =
  let koti = koti_v_skatli in
  let super_grid = konstruiraj_sg sudoku in
  let odgovor = rekurzija sudoku super_grid koti in
  pretvori_v_resitev sudoku odgovor

let get_initial_grid (x : Model.problem) : int option array array =
  x.initial_grid

let solve_problem (problem : Model.problem) =
  problem |> get_initial_grid |> resi


