impl Note {
  fn generate_nullifier(&self) -> Field {
    let note_hash = self.generate_note_hash();
    // This call succeeds only if self.account signed this tx
    let secret_key = oracle.get_secret_key(self.account);
    hash(note_hash, secret_key)
  }
}

impl Note for PartialClaimNote {
  let account: AztecAddress;
  let input_amount: Field;
  let secret: Field;

  fn generate_note_hash(&self) -> Field {
    hash(self.account, self.input_amount, self.secret);
  }
}

impl Note for ClaimNote {
  let account: AztecAddress;
  let secret: Field;
  let value: Field;
  let token_address: AztecAddress;

  fn generate_note_hash(&self) -> Field {
    hash(self.value, self.token_address, hash(account, secret))
  }
}

trait Event {};

struct EncryptedSecret{
  secret: Field;
};

impl Event for EncryptedSecret;

contract ZkToken {
  let private_balances: Map<Set<Note>> = Map::new(); // set of notes
  let public_balances: Map<PublicState> = Map::new(); // public address --> balance

  message portal_transfer_msg(Field: amount,  Field: recipient);


  fn shield() {

  }
  
  fn public_transfer(amount: Field, recipient: AztecAddress) {
    let mut user_balance = private_balances.at(msg.sender);
    // spend my notes
    let (note) = user_balance.get_note(amount); // the note implementation needs to recurse to get a note that is the requesting amount.
    user_balance.remove(note);
    PublicCallStackItem::call(call_context.address, unshield_selector, [amount, recipient]); // ideally replace with self::unshield(amount, recipient);
  }

  open fn unshield(amount: Field, recipient: AztecAddress) {
    assert(msg.sender == this) // auth logic to stop anyone calling this. Would be better to have open internal functions
    // spend my notes
    // would be nice to do ++
    let balance = public_balances.at(recipient).read();
    public_balances.at(recipient).write(balance + amount);
  }

  open fn l1_transfer(amount: Field, to: Field) {

    let balance = public_balances.at(call_context.msg.sender).read();
    public_balances.at(call_context.msg.sender).write(balance - amount);

    send portal_transfer_msg(amount, to);
  }

  // fn create_partial_note(amount: Field, recipient: AztecAddress) {
  //   let secret = oracle.rand();
  //   let note = PartialClaimNote::new(recipient, amount, secret);
  //   let note_hash = claim_note::generate_note_hash();
  //   let encrypted_secret = IAccount.at(call_context.msg_sender)::encrypt_msg(secret);
  //   ctx.push_note_hash(note_hash);
  //   ctx.push_event(EncryptedSecret::new(encrypted_secret));
  // }

  fn complete_partial_note(secret: Field, amount: Field) {
    let partial_note_message = 
    let result = oracle.consume_l1_to_l2_message(content, msgKey, secret)
    // destroy notes

    // create new notes
  }
}