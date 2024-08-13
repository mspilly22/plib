
package txtmsg

import (
    "testing"
    "fmt"
)

func TestSimple(t *testing.T) {
    var typ PayloadType
    typ = PayloadType_PAYLOAD_TYPE_SMALL
    fmt.Printf("Payload type is = %s\n", typ.String())
}
