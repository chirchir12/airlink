defmodule Airlink.Repo.Migrations.CreateAccounting do
  use Ecto.Migration

  def change do
    create table(:accounting) do
      add :acct_delay_time, :bigint
      add :acct_session_id, :string
      add :acct_status_type, :string
      add :acct_unique_session_id, :string, null: false
      add :called_station_id, :string
      add :calling_station_id, :string
      add :framed_ip_address, :string
      add :mikrotik_host_ip, :string
      add :nas_identifier, :string
      add :nas_ip_address, :string
      add :nas_port_id, :string
      add :nas_port_type, :string
      add :user_name, :string
      add :acct_input_gigawords, :bigint
      add :acct_input_octets, :bigint
      add :acct_input_packets, :bigint
      add :acct_output_gigawords, :bigint
      add :acct_output_octets, :bigint
      add :acct_output_packets, :bigint
      add :acct_session_time, :bigint
      add :subscription_id, :uuid
      add :acct_terminate_cause, :string
      add :company_id, :uuid

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounting, [:acct_unique_session_id])
    create index(:accounting, [:subscription_id])
    create index(:accounting, [:nas_identifier])
    create index(:accounting, [:company_id])
    create index(:accounting, [:calling_station_id])
    create index(:accounting, [:acct_session_id])
    create index(:accounting, [:user_name])
  end
end
