contract UniswapPortal {
    IRollup constant ROLLUP = IRollup(0x1234);
    IRegistry immutable registry;
    bytes32 immutable l2ContractAddress;
    IZKTokenPortal immutable zkTokenPortal;

    constructor(bytes _l2ContractAddress, address _zkTokenPortalAddress) {
        registry = IRegistry(ROLLUP.registry());
        l2ContractAddress = _l2ContractAddress;
        zkTokenPortal = IZKTokenPortal(_zkTokenPortalAddress);
        IERC20(zkTokenPortal.underlying()).approve(address(zkTokenPortal), uint256(-1));
    }

    public swap(uint256 _swapId, token_address_a, token_address_b, uint256[] _amounts, bytes32[] _partialNoteHashes) {
        uint256 aggregatedAmount = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            aggregatedAmount += _amounts[i];
        }
        DataStructures.L2ToL1Msg memory message = DataStructures.L2ToL1Msg({
            sender: DataStructures.L2Actor(l2ContractAddress, 1),
            recipient: DataStructures.L1Actor(address(this), 1),
            content: Hash.sha256ToField(
                abi.encodePacked([_swapId, token_address_a, token_address_b, _amounts, _partialNoteHashes])
                )
            });

        bytes32 entryKey = registry.getOutbox().consume(message);

        for (uint256 j = 0; j < _amounts; j++) {
            zkTokenPortal.depositWithPartialNoteHash(_partialNoteHashes[j], _amounts[j]);
        }
    }
}

contract ZkTokenPortal {
    constant IRollup ROLLUP = IRollup(0x1234);
    immutable IRegistry registry;

    constructor() {
        registry = IRegistry(ROLLUP.registry());
    }

  public depositWithPartialNoteHash(bytes32 _partialNoteHash, uint256 _amount) {
    // Hold the tokens in the portal
    underlying.safeTransferFrom(msg.sender, address(this), _amount);

    // Hash the message content to be reconstructed in the receiving contract
    bytes32 content = Hash.sha256ToField(abi.encodePacked([_amounts, _partialNoteHash]));
    
    sendMessageToRollup(content)
  }

  private sendMessageToRollup(bytes32 _content) {
     // Preamble
    IInbox inbox = registry.getInbox();
    DataStructures.L2Actor memory actor = DataStructures.L2Actor(l2TokenAddress, 1);

    // Send message to rollup
    return inbox.sendL2Message{value: msg.value}(actor, _deadline, _content, _secretHash);
  }
}
