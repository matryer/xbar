enum Test<T: Equatable> {
   case succ
   case fail
   /* Exp, Actual */
   case comp(T, T)
   case test(Bool)
}