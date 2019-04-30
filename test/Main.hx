package ;

import tink.unit.*;
import tink.testrunner.Runner;

class Main {

    public static function main() {
        Runner.run(TestBatch.make([
            new be.heed.HeedEncodeSpec(),
            new be.heed.HeedDecodeSpec(),
            new be.heed.HeedEscapeSpec(),
        ]))
        .handle(Runner.exit);
    }

}