defmodule ExBank.BackendDb do
  alias ExBank.Account

  def create_db do
    :ets.new(:accounts, [:set])
  end

  def lookup(reference, acc_no) do
    case :ets.lookup(reference, acc_no) do
      [] -> {:error, :instance}
      [{_acc_no, _name, account}] -> account
    end
  end

  def lookup_by_name(ref, name) do
    :ets.match(ref, {:_, name, :"$2"})
  end

  def new_account(reference, acc_no, pin, name) do
    new_account = %Account{acc_no: acc_no, pin: pin, name: name}
    :ets.insert(reference, {acc_no, name, new_account})
  end

  def credit(ref, acc_no, amount) do
    case lookup(ref, acc_no) do
      {:error, :instance} ->
        {:error, :instance}

      %{balance: balance, name: name, transactions: transactions} = account ->
        acc_updated = %{
          account
          | balance: balance + amount,
            transactions: [{:credit, DateTime.utc_now(), amount} | transactions]
        }

        :ets.insert(ref, {acc_no, name, acc_updated})
    end
  end

  def debit(ref, acc_no, amount) do
    case lookup(ref, acc_no) do
      {:error, :instance} = error_instance ->
        error_instance

      %{balance: balance, name: name, transactions: transactions} = account ->
        if(balance > amount) do
          balance_updated = balance - amount
          transactions_updated = [{:debit, DateTime.utc_now(), amount} | transactions]
          acc_updated = %{account | balance: balance_updated, transactions: transactions_updated}
          :ets.insert(ref, {acc_no, name, acc_updated})
        else
          {:error, :balance}
        end
    end
  end

  def is_pin_valid?(ref, acc_no, pin) do
    %{pin: actual_pin} = lookup(ref, acc_no)
    pin == actual_pin
  end

  def all_accounts(ref) do
    for {_, _, account} <- :ets.tab2list(ref) do
      account
    end
  end

  def close(ref) do
    :ets.delete(ref)
  end
end
