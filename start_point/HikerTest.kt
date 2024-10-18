// [X] See please-help.txt 

package hiker /*[X]*/

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe


class HikerTest : StringSpec() { /*[X]*/

    init {
        "Example Test" {
            hiker.answer() shouldBe 42
        }

        "Other example test" {
            "a" shouldNotBe "b"
        }
    }
}
