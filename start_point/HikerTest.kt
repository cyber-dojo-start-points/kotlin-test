package dojo /* see comment at top of cyber-dojo.sh */

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe


class HikerTest : StringSpec() {

    init {
        "Example Test" {
            answer() shouldBe 42
        }

        "Other example test" {
            "a" shouldNotBe "b"
        }
    }
}
