module ClientHelpers
  def fake_octokit_client
    double().tap do |fake|
      user_response = double()
      allow(user_response).to receive(:login).and_return('mkcode')
      allow(fake).to receive(:user).and_return(user_response)
      allow(fake).to receive(:last_response).and_return(fake_get_response)
    end
  end

  def fake_get_response
    double().tap do |response|
      allow(response).to receive(:headers).and_return({})
      allow(response).to receive(:data).and_return("{login: 'mkcode'}")
      allow(response).to receive(:status).and_return('200')
    end
  end

  def fake_not_modified_response
    double().tap do |response|
      allow(response).to receive(:data).and_return('')
      allow(response).to receive(:headers).and_return('status' => '304 Not Modified')
    end
  end
end
