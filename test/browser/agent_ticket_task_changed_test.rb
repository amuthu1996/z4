require 'browser_test_helper'

class AgentTicketTaskChangedTest < TestCase

  # regression test for issue #2042 - incorrect notification when closing a tab after setting up an object
  def test_detection_of_ticket_update_after_new_attribute
    @browser = instance = browser_instance
    login(
      username: 'master@example.com',
      password: 'test',
      url:      browser_url,
    )
    tasks_close_all()

    ticket_create(
      data: {
        customer: 'nico',
        group:    'Users',
        title:    'test ticket',
        body:     'some body 123äöü',
      },
    )

    object_manager_attribute_create(
      data: {
        name:      'text_test',
        display:   'text_test',
        data_type: 'Text',
      },
    )
    object_manager_attribute_migrate

    ticket_open_by_title(title: 'test ticket')

    # verify the 'Discard your changes' message does not appear (since there are no changes)
    assert_nil execute(js: "return $('.content.active .js-attributeBar .js-reset:not(\".hide\")').get(0)")

    # try and close the existing open ticket window
    instance.action.move_to(instance.find_elements(css: '#navigation .tasks .task:first-child')[0]).release.perform
    instance.find_elements(css: '#navigation .tasks .task:first-child .js-close')[0].click

    sleep 0.5
    exists_not( css: '.modal')

    object_manager_attribute_delete(
      data: {
        name: 'text_test',
      },
    )
    object_manager_attribute_migrate
  end

end
