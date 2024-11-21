# Airlink

Service to handle hotspot functinality for diralink

### Functionalities

1. Create hotspots
2. create plans/packages
3. create hotspot customers
4. handle hotspot payments
5. handle internet subscription for hotspot users

## Environment Configuration

### Airlink Message Queues Configuration

| Queue Name/Consumer           | Routing Key                     | Description                               |
| ----------------------------- | ------------------------------- | ----------------------------------------- |
| airlink_subscription_consumer | hotspot_subscription_changes_rk | Internet Subscription notification        |
| airlink_payment_consumer      | payment_results_rk              | Payment notifications                     |
| airlink_company_consumer      | company_changes_rk              | handle notification for payment changes   |
| airlink_router_consumer       | router_changes_rk               | handle notifications for router changes   |
| airlink_accounting_consumer   | hotspot_accounting_rk           | notifications for hotspot accounting data |
|                               | rmq_plan_changes_rk             | Handle plan/packages notifications        |

###
