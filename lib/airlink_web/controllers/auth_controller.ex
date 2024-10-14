defmodule AirlinkWeb.AuthController do
  use AirlinkWeb, :controller
  alias Airlink.Captive
  alias Airlink.Customers
  alias Airlink.Subscriptions
  alias Airlink.Subscriptions.Subscription

  def login(conn, %{"ref_id" => sub_uud}) do
    with {:ok, %Subscription{customer_id: customer_id} = sub} <-
           Subscriptions.get_subscription_by_uuid(sub_uud),
         {:not_expired, _sub} <- Subscriptions.check_status(sub),
         {:ok, customer} <- Customers.get_customer_by_id(customer_id),
         {:ok, captive_entry} <- Captive.get_entry(customer_id) do
          _ = Captive.delete_entry(customer_id)
      conn
      |> render(:auth, data: {customer, captive_entry})
    end
  end
end
