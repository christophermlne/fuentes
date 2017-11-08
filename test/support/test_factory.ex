defmodule Fuentes.TestFactory do
  use ExMachina.Ecto, repo: Fuentes.TestRepo

  alias Fuentes.{Account, Amount, Entry}

  def account_factory do
    %Account{
      name: "My Assets",
      type: "asset",
      contra: false,
      uuid: generate_rand_string()
    }
  end

  def entry_factory do
    %Entry{
      description: "Investing in Koenigsegg",
      date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
      amounts: [ build(:credit), build(:debit) ]
    }
  end

  def credit_factory do
    %Amount{
      amount: Decimal.new(125000.00),
      type: "credit",
      account_id: 1
    }
  end

  def debit_factory do
    %Amount{
      amount: Decimal.new(125000.00),
      type: "debit",
      account_id: 2
    }
  end

  def generate_rand_string()do
     Enum.reduce((1..16), [], fn (_i, acc) ->
          [Enum.random(@chars) | acc]
        end) |> Enum.join("")
  end
end
