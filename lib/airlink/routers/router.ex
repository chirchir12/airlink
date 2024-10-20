defmodule Airlink.Routers.Router do
  defstruct id: nil,
            nasname: nil,
            shortname: nil,
            type: nil,
            ports: nil,
            secret: nil,
            server: nil,
            community: nil,
            description: nil,
            company_id: nil,
            router_id: nil

  def new(attrs) when is_map(attrs) do
    struct(__MODULE__, attrs)
  end
end
