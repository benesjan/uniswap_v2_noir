use dep::aztec::IZkToken;
use dep:std::pedderson;

struct Deposit {
  amount: Field;
  claim_note_hash: Field;
}


trait L1L2Message {};

struct Swap{
  swapId: Field;
  token_address_a: Field;
  token_address_b: Field;
  amount_in: Field;
};

impl L1L2Message for Swap;

trait L2L1Message {};

struct SwapResult {
  swapId: Field;
  token_address_a: Field;
  token_address_b: Field;
  amount_in: Field;
  total_amount_out: Field;
  succeeded: bool;
}

impl L2L1Message for SwapResult;

contract Uniswap {
  let partial_notes = Set::new();
  let token_address_a = AztecAddress();
  let token_address_b = AztecAddress();
  let mut swapId = 0;
  // let swapId: PublicState<u32> = PublicState::new();
  let deposits: PublicSet<Deposit> = PublicSet::new();
  // let claims: Map<Set<ClaimNote>> = Map::new();
  
  fn setupSwap(amount: Field) {
    PrivateCallStackItem::call(token_address_a, public_transfer_selector, [amount, call_context.address]); // IZkToken.at(token_address_a)::public_transfer(amount, call_context.address); is way nicer.
    IZkToken::user_create_partial_note();
    PublicCallStackItem::call(call_context.address, swap_selector, [amount, token_address_a, token_address_b, claim_note_hash]); // self::swap() is way better
  }

  open fn swap(amount: Field, token_address_a: AztecAddress, token_address_b: AztecAddress, claim_note_hash: Field) {
      // read public state to get the current swapID for a given token
      // increment public state to add the amount to the swap id and counter
      // write the recipient to public state so it can later be distributed to fairly
      // read public state to get the current threshold and counter

      // we are missing public state structs e.g arrays, mappings etc.
      
      deposits.insert(Deposit::new(amount, claim_note_hash));


      // we want sets of sets of sets in the public land.
      // depositsForSwap[token_address_a][token_address_b].insert({
      //  amount,
      // hidden_recipient
      // })
      

      if (deposits.len() > threshold) {
        swapId += 1;

        // we could loop over the deposits and sum
        let aggregated_amount = 0;
        for (i in 0..deposits.len()) {
          aggregated_amount += amount;
          ctx.push_note_hash(deposits[i].note_hash);
        }
        
        let msg = Swap::new(swapId, token_address_a, token_address_b, aggregated_amount)
        ctx.push_l2_to_l1_msg(msg);

        IZkToken::l1Transfer(aggregated_amount, self::portal_address);
      }

  }
}
