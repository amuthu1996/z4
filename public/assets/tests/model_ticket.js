window.onload = function() {

  App.Ticket.refresh([{
    id: 1,
    title: 'ticket1',
    state_id: 1,
    customer_id: 33,
    organization_id: 1,
    owner_id: 1,
  },
  {
    id: 2,
    title: 'ticket2',
    state_id: 1,
    customer_id: 44,
    organization_id: 1,
    owner_id: 1,
  },
  {
    id: 3,
    title: 'ticket3',
    state_id: 1,
    customer_id: 55,
    organization_id: undefined,
    owner_id: 1,
  },
  {
    id: 4,
    title: 'ticket4',
    state_id: 1,
    customer_id: 66,
    organization_id: undefined,
    owner_id: 1,
    group_id: 1,
  }])

  App.User.refresh([{
    id: 33,
    login: 'hh@1example.com',
    firstname: 'Harald',
    lastname: 'Habebe',
    email: 'hh1@example.com',
    organization_id: 1,
    role_ids: [3],
    active: true,
  },
  {
    id: 44,
    login: 'hh2@example.com',
    firstname: 'Harald',
    lastname: 'Habebe',
    email: 'hh2@example.com',
    organization_id: 2,
    role_ids: [3],
    active: true,
  },
  {
    id: 55,
    login: 'hh3example.com',
    firstname: 'Harald',
    lastname: 'Habebe',
    email: 'hh3@example.com',
    organization_id: undefined,
    role_ids: [3],
    active: true,
  }])

  test('ticket.editabe customer user #1', function() {
    App.Session.set(33)
    ticket1 = App.Ticket.find(1);
    ok(ticket1.editable(), 'access via customer_id');
    ticket2 = App.Ticket.find(2);
    ok(ticket2.editable(), 'access via organization_id');
    ticket3 = App.Ticket.find(3);
    ok(!ticket3.editable(), 'no access');
    ticket4 = App.Ticket.find(4);
    ok(!ticket4.editable(), 'no access');
  });

  test('ticket.editabe customer user #2', function() {
    App.Session.set(44)
    ticket1 = App.Ticket.find(1);
    ok(!ticket1.editable(), 'no access');
    ticket2 = App.Ticket.find(2);
    ok(ticket2.editable(), 'access via customer_id');
    ticket3 = App.Ticket.find(3);
    ok(!ticket3.editable(), 'no access');
    ticket4 = App.Ticket.find(4);
    ok(!ticket4.editable(), 'no access');
  });

  test('ticket.editabe customer user #3', function() {
    App.Session.set(55)
    ticket1 = App.Ticket.find(1);
    ok(!ticket1.editable(), 'no access');
    ticket2 = App.Ticket.find(2);
    ok(!ticket2.editable(), 'no access');
    ticket3 = App.Ticket.find(3);
    ok(ticket3.editable(), 'access via customer_id');
    ticket4 = App.Ticket.find(4);
    ok(!ticket4.editable(), 'no access');
  });

}
