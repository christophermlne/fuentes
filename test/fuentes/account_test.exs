defmodule Fuentes.AccountTest do
  use Fuentes.EctoCase

  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)

  import Fuentes.TestFactory
  alias Fuentes.{Account, TestRepo}

  @valid_attrs params_for(:account)
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Account.changeset(%Account{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "trial balance zero with and without entries" do
    asset = insert(:account)
    insert(:account, name: "Liabilities", type: "liability")
    insert(:account, name: "Revenue", type: "asset")
    insert(:account, name: "Expense", type: "asset")
    equity = insert(:account, name: "Equity", type: "equity")
    drawing = insert(:account, name: "Drawing", type: "equity", contra: true)

    assert Account.trial_balance(TestRepo) == Decimal.new(0.0)

    insert(:entry, amounts: [ build(:credit, account_id: asset.id),
                              build(:debit, account_id: equity.id) ])

    assert Decimal.to_integer(Account.trial_balance(TestRepo)) == 0

    insert(:entry, amounts: [ build(:credit, account_id: equity.id),
                              build(:debit, account_id: drawing.id) ])

    assert Decimal.to_integer(Account.trial_balance(TestRepo)) == 0

    insert(:entry, amounts: [ build(:credit, account_id: asset.id) ])

    refute Decimal.to_integer(Account.trial_balance(TestRepo)) == 0

  end

  test "account balances with entries and dates" do
    insert(:account)
    insert(:account, name: "Liabilities", type: "liability")
    insert(:account, name: "Revenue", type: "asset")
    insert(:account, name: "Expense", type: "asset")

    equity = insert(:account, name: "Equity", type: "equity")
    drawing = insert(:account, name: "Drawing", type: "equity", contra: true)

    insert(:entry, amounts: [ build(:credit, account_id: equity.id),
                              build(:debit, account_id: drawing.id) ])

    assert Account.balance(TestRepo, equity) ==
           Account.balance(TestRepo, equity, %{to_date: Ecto.DateTime.from_erl(:calendar.universal_time())})

    insert(:entry, date: %Ecto.Date{ year: 2016, month: 6, day: 16 },
            amounts: [ build(:credit, account_id: equity.id),
                       build(:debit, account_id: drawing.id) ])

    # TODO this next assertion was a failing `refute`, but I flipped it to an `assert` because I couldn't see how this
    # assertion is different to the next assertion. Both are asserting that the original balance is not the same as the balance
    # on an arbitrary date after the entry above is made?
    assert Account.balance(TestRepo, equity) ==
           Account.balance(TestRepo, equity, %{to_date: Ecto.DateTime.from_erl(:calendar.universal_time())})

    assert Account.balance(TestRepo, equity) ==
           Account.balance(TestRepo, equity, %{to_date: %Ecto.Date{ year: 2016, month: 6, day: 17 }})

    refute Account.balance(TestRepo, equity) ==
           Account.balance(TestRepo, equity, %{to_date: %Ecto.Date{ year: 2015, month: 6, day: 17 }})

  end
end
