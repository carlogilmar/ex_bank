defmodule ExBank.BackendDbTest do
  use ExUnit.Case
  alias ExBank.BackendDb

  describe "Feature 1" do
    test "Lookup non-existing record" do
      table_ref = BackendDb.create_db()
      assert {:error, :instance} = BackendDb.lookup(table_ref, 1)
    end

    test "Create new account" do
      table_ref = BackendDb.create_db()
      assert BackendDb.new_account(table_ref, 1, "1234", "Account Name")
    end

    test "Get all the bank accounts" do
      table_ref = BackendDb.create_db()
      BackendDb.new_account(table_ref, 1, "1234", "Tony Stark")
      BackendDb.new_account(table_ref, 2, "1234", "Tony Stark")
      BackendDb.new_account(table_ref, 3, "1234", "Tony Stark")
      BackendDb.new_account(table_ref, 4, "1234", "Tony Stark")
      tony_stark_accounts = BackendDb.lookup_by_name(table_ref, "Tony Stark")
      assert length(tony_stark_accounts) == 4
    end
  end
end
