defmodule ExBank.Account do
  defstruct [
    :acc_no,
    :pin,
    :name,
    balance: 0,
    transactions: []
  ]
end
