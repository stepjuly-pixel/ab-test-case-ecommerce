with session_info as (
  select
    ss.date,
    ss.ga_session_id,
    sp.country,
    sp.device,
    sp.continent,
    sp.channel,
    ab.test,
    ab.test_group
  from `DA.ab_test` ab
  join `DA.session` ss
    on ab.ga_session_id = ss.ga_session_id
  join `DA.session_params` sp
    on sp.ga_session_id = ab.ga_session_id
),

session_with_orders as (
  select
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group,
    count(distinct o.ga_session_id) as session_with_orders
  from `DA.order` o
  join session_info as si
    on si.ga_session_id = o.ga_session_id
  group by
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group
),

events as (
  select
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group,
    ep.event_name,
    count(ep.ga_session_id) as event_cnt
  from `DA.event_params` ep
  join session_info si
    on ep.ga_session_id = si.ga_session_id
  group by
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group,
    ep.event_name
),

session as (
  select
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group,
    count(distinct si.ga_session_id) as session_cnt
  from session_info si
  group by
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group
),

account as (
  select
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group,
    count(distinct acs.ga_session_id) as new_account_cnt
  from `DA.account_session` acs
  join session_info si
    on acs.ga_session_id = si.ga_session_id
  group by
    si.date,
    si.country,
    si.device,
    si.continent,
    si.channel,
    si.test,
    si.test_group
)

select
  session_with_orders.date,
  session_with_orders.country,
  session_with_orders.device,
  session_with_orders.continent,
  session_with_orders.channel,
  session_with_orders.test,
  session_with_orders.test_group,
  'session with orders' as event_name,
  session_with_orders.session_with_orders as value
from session_with_orders

union all

select
  events.date,
  events.country,
  events.device,
  events.continent,
  events.channel,
  events.test,
  events.test_group,
  event_name,
  event_cnt as value
from events

union all

select
  session.date,
  session.country,
  session.device,
  session.continent,
  session.channel,
  session.test,
  session.test_group,
  'session' as event_name,
  session_cnt as value
from session

union all

select
  account.date,
  account.country,
  account.device,
  account.continent,
  account.channel,
  account.test,
  account.test_group,
  'new account' as event_name,
  new_account_cnt as value
from account
