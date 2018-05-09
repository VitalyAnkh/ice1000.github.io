# Kotlin Function Composition

```kotlin
operator fun <A, B, C> ((B) -> A).plus(p: (C) -> B) = { it: C -> this(p(it)) }

fun main(args: Array<String>) {
  val a: (Int) -> String = { it.toString() }
  val b: (String) -> ByteArray = { it.toByteArray() }
  println((b + a)(233))
  val c: (ByteArray) -> List<Int> = { it.map { it.toInt() } }
  println((c + b + a)(666)) // Haskell: c . b . a $ 666
}
```
