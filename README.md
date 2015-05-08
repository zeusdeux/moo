# moks
An interpreted language written @recursecenter

Sample program in `moks`:

```moks
let fib n = {
  if (n == 0 || n == 1) {
     1
  } {
     fib (n-1) + fib (n-2)
  }
}

print (fib 10)

```

Things/features I plan to experiment with in the future:

- module system
- marking side effects syntactically
- calls into javascript
- runtime optimizations
- stack based runtime (currently uses the underlying js runtime stack)
- macros
- simple type system
- pausable and rewindable code editing
