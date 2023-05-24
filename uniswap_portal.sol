contract UniswapPortal {
    public distributeProceeds() {
        // We grab any message which can be consumed/whose swap is finalised
        

    let message: SwapResult = oracle.consume_l1_to_l2_message(content, msgKey, secret)
    let token_address = message.succeeded ? message.token_address_b : message.token_address_a;
    // This could be set by portal contract when emitting the message
    let total_amount_out = message.succeeded ? message.amount_out : message.amount_in;
    for (i in 0..deposits.len()) {
      let deposit = deposits[i];
      let amount_out = (deposit.amount / message.amount_in) * total_amount_out;
      let note_hash = hash(amount_out, token_address, deposit.note_hash);
      ctx.push_note_hash(note_hash);
    }
  }

  public  claim() {
    let claim_note = claims.at(call_context.msg_sender).get_1();
    assert(claim_note);
    claims.remove(claim_note);
    IZkToken::approve();
  }
}

DataStructures.L2ToL1Msg memory message = DataStructures.L2ToL1Msg({
      sender: DataStructures.L2Actor(aztecAddress, 1),
      recipient: DataStructures.L1Actor(address(this), block.chainid),
      content: Hash.sha256ToField(
        abi.encodeWithSignature("withdraw(uint256,address)", _amount, _recipient)
        )
    });

    bytes32 entryKey = registry.getOutbox().consume(message);

contract ZkTokenPortal {
    constant IRollup ROLLUP = IRollup(0x1234);
    immutable IRegistry registry;

    constructor() {
        registry = IRegistry(ROLLUP.registry());
    }

  public depositWithPartialNoteHash(bytes32 _partialNoteHash, uint256 _amount) {
    // Preamble
    IInbox inbox = registry.getInbox();
    DataStructures.L2Actor memory actor = DataStructures.L2Actor(l2TokenAddress, 1);

    // Hash the message content to be reconstructed in the receiving contract
    bytes32 content =
      Hash.sha256ToField(abi.encodeWithSignature("mint(uint256,bytes32)", _amount, _partialNoteHash));

    // Hold the tokens in the portal
    underlying.safeTransferFrom(msg.sender, address(this), _amount);

    // Send message to rollup
    return inbox.sendL2Message{value: msg.value}(actor, _deadline, content, _secretHash);
  }
}
