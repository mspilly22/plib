
package descpb

import (
    "testing"
    "github.com/stretchr/testify/require"
)

func TestSimple(t *testing.T) {
    ws1 := WaitStats{
        NumRetries: 5,
        LastCount: 1,
    }
    encode, err := ws1.Marshal()
    require.NoError(t, err)
    ws2 := WaitStats{}
    err = ws2.Unmarshal(encode)
    require.NoError(t, err)
    require.Equal(t, ws1.NumRetries, ws2.NumRetries)
    require.Equal(t, ws1.LastCount, ws2.LastCount)
}
