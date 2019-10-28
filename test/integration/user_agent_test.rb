require 'integration_test_helper'

class UserAgentTest < ActiveSupport::TestCase
  host = 'https://r2d2.znuny.com'
  #host = 'http://127.0.0.1:3003'

  setup do
    if ENV['ZAMMAD_PROXY_TEST'] == 'true'
      Setting.set('proxy', ENV['ZAMMAD_PROXY'])
      Setting.set('proxy_username', ENV['ZAMMAD_PROXY_USERNAME'])
      Setting.set('proxy_password', ENV['ZAMMAD_PROXY_PASSWORD'])
    end
  end

  # check
  test 'check some results' do

    # get / 200
    result = UserAgent.get(
      "#{host}/test/get/1?submitted=123",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"123"/)
    assert(result.body =~ /"content_type_requested":null/)
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # get / 404
    result = UserAgent.get(
      "#{host}/test/not_existing",
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)

    # post / 200
    result = UserAgent.post(
      "#{host}/test/post/1",
      {
        submitted: 'some value',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('201', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"post"/)
    assert(result.body =~ /"some value"/)
    assert(result.body =~ %r{"application/x-www-form-urlencoded"})
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # post / 404
    result = UserAgent.post(
      "#{host}/test/not_existing",
      {
        submitted: 'some value',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)

    # put / 200
    result = UserAgent.put(
      "#{host}/test/put/1",
      {
        submitted: 'some value',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"put"/)
    assert(result.body =~ /"some value"/)
    assert(result.body =~ %r{"application/x-www-form-urlencoded"})
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # put / 404
    result = UserAgent.put(
      "#{host}/test/not_existing",
      {
        submitted: 'some value',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)

    # delete / 200
    result = UserAgent.delete(
      "#{host}/test/delete/1",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"delete"/)
    assert(result.body =~ /"content_type_requested":null/)
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # delete / 404
    result = UserAgent.delete(
      "#{host}/test/not_existing",
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)

    # with http basic auth

    # get / 200
    result = UserAgent.get(
      "#{host}/test_basic_auth/get/1?submitted=123",
      {},
      {
        user:     'basic_auth_user',
        password: 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"123"/)
    assert(result.body =~ /"content_type_requested":null/)
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # get / 401
    result = UserAgent.get(
      "#{host}/test_basic_auth/get/1?submitted=123",
      {},
      {
        user:     'basic_auth_user_not_existing',
        password: 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal("HTTP Basic: Access denied.\n", result.body)

    # post / 200
    result = UserAgent.post(
      "#{host}/test_basic_auth/post/1",
      {
        submitted: 'some value',
      },
      {
        user:     'basic_auth_user',
        password: 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('201', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"post"/)
    assert(result.body =~ /"some value"/)
    assert(result.body =~ %r{"application/x-www-form-urlencoded"})
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # post / 401
    result = UserAgent.post(
      "#{host}/test_basic_auth/post/1",
      {
        submitted: 'some value',
      },
      {
        user:     'basic_auth_user_not_existing',
        password: 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal("HTTP Basic: Access denied.\n", result.body)

    # put / 200
    result = UserAgent.put(
      "#{host}/test_basic_auth/put/1",
      {
        submitted: 'some value',
      },
      {
        user:     'basic_auth_user',
        password: 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"put"/)
    assert(result.body =~ /"some value"/)
    assert(result.body =~ %r{"application/x-www-form-urlencoded"})
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # put / 401
    result = UserAgent.put(
      "#{host}/test_basic_auth/put/1",
      {
        submitted: 'some value',
      },
      {
        user:     'basic_auth_user_not_existing',
        password: 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal("HTTP Basic: Access denied.\n", result.body)

    # delete / 200
    result = UserAgent.delete(
      "#{host}/test_basic_auth/delete/1",
      {
        user:     'basic_auth_user',
        password: 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"delete"/)
    assert(result.body =~ /"content_type_requested":null/)
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # delete / 401
    result = UserAgent.delete(
      "#{host}/test_basic_auth/delete/1",
      {
        user:     'basic_auth_user_not_existing',
        password: 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal("HTTP Basic: Access denied.\n", result.body)
  end

  # check
  test 'check redirect' do

    # get / 301
    result = UserAgent.request(
      "#{host}/test/redirect",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"abc"/)
    assert(result.body =~ /"content_type_requested":null/)
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # get / 301
    result = UserAgent.request(
      "#{host}/test_basic_auth/redirect",
      {
        user:     'basic_auth_user',
        password: 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"abc"/)
    assert(result.body =~ /"content_type_requested":null/)
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # get / 401
    result = UserAgent.request(
      "#{host}/test_basic_auth/redirect",
      {
        user:     'basic_auth_user_not_existing',
        password: 'test123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal("HTTP Basic: Access denied.\n", result.body)
  end

  # check
  test 'check request' do

    # get / 200
    result = UserAgent.request(
      "#{host}/test/get/1?submitted=123",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"123"/)
    assert(result.body =~ /"content_type_requested":null/)
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # ftp / 200
    result = UserAgent.request(
      #'ftp://root.cern.ch/pub/README-root-build.txt',
      'ftp://ftp.gwdg.de/pub/rfc/rfc-index.txt',
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /instructions/i)

    # ftp / 401
    result = UserAgent.request(
      #'ftp://root.cern.ch/pub/not_existing.msg',
      'ftp://ftp.gwdg.de/pub/rfc/not_existing.txt',
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('550', result.code)
    assert_equal(NilClass, result.body.class)

    # get / 200 / gzip
    result = UserAgent.request(
      'https://httpbin.org/gzip',
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

    # get / 200 / gzip
    result = UserAgent.request(
      'http://httpbin.org/gzip',
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

    # get / 200 / gzip
    result = UserAgent.request(
      'https://httpbin.org/deflate',
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

    # get / 200 / gzip
    result = UserAgent.request(
      'http://httpbin.org/deflate',
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

  end

  # check
  test 'check not existing' do

    # get / 0
    result = UserAgent.request(
      'http://not.existing.host/test.php',
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)

    # ftp / 0
    result = UserAgent.request(
      'ftp://not.existing.host/test.bin',
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)
  end

  # check
  test 'check timeout' do

    # get / timeout
    result = UserAgent.get(
      "#{host}/test/get/3?submitted=123",
      {},
      {
        open_timeout: 1,
        read_timeout: 1,
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)

    # post / timeout
    result = UserAgent.post(
      "#{host}/test/post/3",
      {
        submitted: 'timeout',
      },
      {
        open_timeout: 1,
        read_timeout: 1,
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)
  end

  # check
  test 'check json' do

    # get / 200
    result = UserAgent.get(
      "#{host}/test/get/1",
      {
        submitted: { key: 'some value ' }
      },
      {
        json: true,
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"content_type_requested"/)
    assert(result.body =~ %r{"application/json"})
    assert_equal('some value ', result.data['submitted']['key'])
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end

    # get / 404
    result = UserAgent.get(
      "#{host}/test/not_existing",
      {
        submitted: { key: 'some value ' }
      },
      {
        json: true,
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)
    assert_not(result.data)

    # post / 200
    result = UserAgent.post(
      "#{host}/test/post/1",
      {
        submitted: { key: 'some value ' }
      },
      {
        json: true,
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('201', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"content_type_requested"/)
    assert(result.body =~ %r{"application/json"})
    assert_equal('some value ', result.data['submitted']['key'])
    if ENV['ZAMMAD_PROXY_TEST'] == 'true' && ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']
      assert(result.body =~ /"remote_ip":"#{ENV['ZAMMAD_PROXY_REMOTE_IP_CHECK']}"/)
    end
  end

end
