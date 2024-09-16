package syncer

import (
	"fmt"
	"strings"

	"github.com/gateway-fm/cdk-erigon-lib/common"
	"github.com/ledgerwatch/erigon/accounts/abi"
	"github.com/ledgerwatch/erigon/zk/contracts"
)

type SequencedBatch struct {
	Transactions         []byte
	ForcedGlobalExitRoot common.Hash
	ForcedTimestamp      uint64
	ForcedBlockHashL1    common.Hash
}

type SequenceBatchesCalldata struct {
	Batches              []SequencedBatch
	InitSequencedBatch   uint64
	L2Coinbase           common.Address
	MaxSequenceTimestamp uint64
}

func DecodeEtrogSequenceBatchesCallData(data []byte) (calldata *SequenceBatchesCalldata, err error) {
	abi2, err := abi.JSON(strings.NewReader(contracts.SequenceBatchesAbiv6_6))
	if err != nil {
		return nil, fmt.Errorf("error parsing etrogPolygonZkEvmAbi to json: %v", err)
	}

	// recover Method from signature and ABI
	method, err := abi2.MethodById(data)
	if err != nil {
		return nil, fmt.Errorf("error recovering method from signature: %v", err)
	}

	//sanitycheck
	if method.Name != "sequenceBatches" {
		return nil, fmt.Errorf("method name is not sequenceBatches, got: %s", method.Name)
	}

	unpackedCalldata := make(map[string]interface{})
	if err := method.Inputs.UnpackIntoMap(unpackedCalldata, data[4:] /*first 4 bytes are method signature and not needed */); err != nil {
		return nil, fmt.Errorf("error unpacking data: %v", err)
	}

	unpackedbatches := unpackedCalldata["batches"].([]struct {
		Transactions         []uint8   `json:"transactions"`
		ForcedGlobalExitRoot [32]uint8 `json:"forcedGlobalExitRoot"`
		ForcedTimestamp      uint64    `json:"forcedTimestamp"`
		ForcedBlockHashL1    [32]uint8 `json:"forcedBlockHashL1"`
	})

	calldata = &SequenceBatchesCalldata{
		Batches:              make([]SequencedBatch, len(unpackedbatches)),
		InitSequencedBatch:   unpackedCalldata["initSequencedBatch"].(uint64),
		L2Coinbase:           unpackedCalldata["l2Coinbase"].(common.Address),
		MaxSequenceTimestamp: unpackedCalldata["maxSequenceTimestamp"].(uint64),
	}

	for i, batch := range unpackedbatches {
		calldata.Batches[i] = SequencedBatch{
			Transactions:         batch.Transactions,
			ForcedGlobalExitRoot: common.BytesToHash(batch.ForcedGlobalExitRoot[:]),
			ForcedTimestamp:      batch.ForcedTimestamp,
			ForcedBlockHashL1:    common.BytesToHash(batch.ForcedBlockHashL1[:]),
		}
	}

	return
}

type SequencedBatchPreEtrog struct {
	Transactions       []uint8
	GlobalExitRoot     common.Hash
	Timestamp          uint64
	MinForcedTimestamp uint64
}

type SequenceBatchesCalldataPreEtrog struct {
	Batches    []SequencedBatchPreEtrog
	L2Coinbase common.Address
}

func DecodePreEtrogSequenceBatchesCallData(data []byte) (calldata *SequenceBatchesCalldataPreEtrog, err error) {
	abi2, err := abi.JSON(strings.NewReader(contracts.SequenceBatchesPreEtrog))
	if err != nil {
		return nil, fmt.Errorf("error parsing etrogPolygonZkEvmAbi to json: %v", err)
	}

	// recover Method from signature and ABI
	method, err := abi2.MethodById(data)
	if err != nil {
		return nil, fmt.Errorf("error recovering method from signature: %v", err)
	}

	//sanitycheck
	if method.Name != "sequenceBatches" {
		return nil, fmt.Errorf("method name is not sequenceBatches, got: %s", method.Name)
	}

	unpackedCalldata := make(map[string]interface{})
	if err := method.Inputs.UnpackIntoMap(unpackedCalldata, data[4:] /*first 4 bytes are method signature and not needed */); err != nil {
		return nil, fmt.Errorf("error unpacking data: %v", err)
	}

	unpackedbatches := unpackedCalldata["batches"].([]struct {
		Transactions       []uint8   `json:"transactions"`
		GlobalExitRoot     [32]uint8 `json:"globalExitRoot"`
		Timestamp          uint64    `json:"timestamp"`
		MinForcedTimestamp uint64    `json:"minForcedTimestamp"`
	})

	calldata = &SequenceBatchesCalldataPreEtrog{
		Batches:    make([]SequencedBatchPreEtrog, len(unpackedbatches)),
		L2Coinbase: unpackedCalldata["l2Coinbase"].(common.Address),
	}

	for i, batch := range unpackedbatches {
		calldata.Batches[i] = SequencedBatchPreEtrog{
			Transactions:       batch.Transactions,
			GlobalExitRoot:     common.BytesToHash(batch.GlobalExitRoot[:]),
			Timestamp:          batch.Timestamp,
			MinForcedTimestamp: batch.MinForcedTimestamp,
		}
	}

	return
}
