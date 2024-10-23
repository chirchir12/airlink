# Airlink

Service to handle hotspot functinality for diralink

### Functionalities

1. Create hotspots
2. create plans/packages
3. create hotspot customers
4. handle hotspot payments
5. handle internet subscription for hotspot users

## Message Queues Required to be set

| Queue Name/Consumer           | Routing Key             | Description                             |
| ----------------------------- | ----------------------- | --------------------------------------- |
| airlink_subscription_consumer | subscription_changes_rk | Internet Subscription notification      |
| airlink_payment_consumer      | payment_results_rk      | Payment notifications                   |
| airlink_company_consumer      | company_changes_rk      | handle notification for payment changes |
| airlink_router_consumer       | router_changes_rk       | handle notifications for router changes |
