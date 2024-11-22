defmodule Airlink.Accounting.Accounting do
  use Ecto.Schema
  import Ecto.Changeset

  @permitted_fields [
    :acct_delay_time,
    :acct_session_id,
    :acct_status_type,
    :acct_unique_session_id,
    :called_station_id,
    :calling_station_id,
    :framed_ip_address,
    :mikrotik_host_ip,
    :nas_identifier,
    :nas_ip_address,
    :nas_port_id,
    :nas_port_type,
    :user_name,
    :acct_input_gigawords,
    :acct_input_octets,
    :acct_input_packets,
    :acct_output_gigawords,
    :acct_output_octets,
    :acct_output_packets,
    :acct_session_time,
    :subscription_id,
    :acct_terminate_cause,
    :company_id,
    :inserted_at,
    :updated_at
  ]

  schema "accounting" do
    field :acct_delay_time, :integer
    field :acct_session_id, :string
    field :acct_status_type, :string
    field :acct_unique_session_id, :string
    field :called_station_id, :string
    field :calling_station_id, :string
    field :framed_ip_address, :string
    field :mikrotik_host_ip, :string
    field :nas_identifier, :string
    field :nas_ip_address, :string
    field :nas_port_id, :string
    field :nas_port_type, :string
    field :user_name, :string
    field :acct_input_gigawords, :integer
    field :acct_input_octets, :integer
    field :acct_input_packets, :integer
    field :acct_output_gigawords, :integer
    field :acct_output_octets, :integer
    field :acct_output_packets, :integer
    field :acct_session_time, :integer
    field :subscription_id, Ecto.UUID
    field :acct_terminate_cause, :string
    field :company_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, @permitted_fields)
    |> validate_required([:acct_unique_session_id])
    |> unique_constraint(:acct_unique_session_id, name: "accounting_acct_unique_session_id_key")
    |> unique_constraint(:id, name: "accounting_pkey")
  end
end
