## 5.0.0 (unreleased)

* Support for LLVM 5.0

    We only give a summary of the changes affecting the public API of `llvm-hs-pure` here.
    Please refer to the official
    [release notes for LLVM 5.0](http://releases.llvm.org/5.0.0/docs/ReleaseNotes.html)
    for an overview of all changes in LLVM 5.0.

    * The `X86_64_Win64` calling convention is now called `Win64`.
    * There is a new `Speculatable` function attribute.
    * The `CrossThread` synchronization scope has been removed. There is
      now a new `System` synchronization scope.

## 4.1.0 (2017-05-17)

* Switch AST to `ByteString`/`ShortByteString` reflecting LLVM’s use
  of C-style strings.
* `preferredAlignment` is now a `Word32` instead of `Maybe Word32`. To
  recover the old behavior set it to the same value as abiAlignment.
* `GlobalAlias` now expects the element type of a pointer type instead
  of the pointer type itself. The address space is passed separately
  via the `addrSpace` field. This makes `GlobalAlias` consistent with
  `GlobalVariable`.
* The `FloatingPointType` constructor now takes a `FloatingPointType` argument
  instead of a width and a `FloatingPointFormat` to more closely match the
  LLVM IR language reference.
* The `IsString` instance of `Name` now throws an error on non-ASCII
  strings instead of silently discarding the upper bytes. There is
  also a new `mkName` function with the same behavior for easier
  discoverability. Non-ASCII names need to be encoded using an arbitrary encoding to
  to a `ShortByteString` which can then be used as a `Name`.

## 4.0.0 (initial release, changes in comparison to llvm-general)

* Move modules from `LLVM.General*` to `LLVM.*`
* Support for LLVM 4.0
* Improved support for LLVM’s exception handling instructions
* `-fshared-llvm` is now supported on windows (thanks to @RyanGLScott)
* Default to `-fshared-llvm`
* Expose `LLVM.Internal.*` modules.
