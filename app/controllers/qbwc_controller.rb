class QbwcController < ApplicationController
  require "Quickbooks"
  protect_from_forgery :except => :api
  def qwc
    qwc = <<-QWC
    <QBWCXML>
    <AppName>#{Rails.application.class.parent_name} #{Rails.env}</AppName>
    <AppID></AppID>
    <AppURL>#{quickbooks_url(:protocol => 'https://', :action => 'api')}</AppURL>
    <AppDescription>I like to describe my awesome app</AppDescription>
    <AppSupport>#{QBWC.support_site_url}</AppSupport>
    <UserName>#{QBWC.username}</UserName>
    <OwnerID>#{QBWC.owner_id}</OwnerID>
    <FileID>{90A44FB5-33D9-4815-AC85-BC87A7E7D1EB}</FileID>
    <QBType>QBFS</QBType>
    <Style>Document</Style>
    <Scheduler>
    <RunEveryNMinutes>5</RunEveryNMinutes>
    </Scheduler>
    </QBWCXML>
    QWC
    send_data qwc, :filename => 'name_me.qwc'
  end

  def api
    # respond successfully to a GET which some versions of the Web Connector send to verify the url

    if request.get?
      render :nothing => true
      return
    end

    #Just a cheap way to add a job for every request.

    # if params["Envelope"]["Body"].keys.first =="authenticate"
    #   QBWC.add_job(:import_vendors) do
    #     '<QBXML>
    #     <QBXMLMsgsRq onError="continueOnError">
    #     <VendorQueryRq requestID="6" iterator="Start">
    #     <MaxReturned>5</MaxReturned>
    #     <FromModifiedDate>1984-01-29T22:03:19-05:00</FromModifiedDate>
    #     <OwnerID>0</OwnerID>
    #   </VendorQueryRq>
    #   </QBXMLMsgsRq>
    #   </QBXML>
    #   '
    #   end

    #   QBWC.jobs[:import_vendors].set_response_proc do |qbxml|
    #     puts "====================Dumping QBXML====================="
    #     puts qbxml
    #   end

    # end

    req = request
    Rails.logger.info "========== #{ params["Envelope"]["Body"].keys.first}  =========="
    res = QBWC::SoapWrapper.route_request(req)
    Rails.logger.info render :xml => res, :content_type => 'text/xml'
  end

end
