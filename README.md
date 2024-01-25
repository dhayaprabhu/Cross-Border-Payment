# CrossBorderPayment:
1. The contract owner initiates a payment by calling the `initiatePayment` function, specifying the recipient's address and the amount.
2. The `initiatePayment` function emits a `PaymentInitiated` event to log the details of the initiated transaction.
3. The contract owner completes the payment by calling the `completePayment` function, specifying the payer's address, recipient's address, and the amount.
4. The `completePayment` function checks that the payer, recipient, and amount are valid and that the contract has a sufficient balance.
5. If the conditions are met, it transfers the specified amount of tokens from the payer to the recipient, A `PaymentCompleted` event is emitted to log the details of the completed transaction.
