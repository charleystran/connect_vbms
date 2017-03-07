module VBMS
  module Requests
    class GetDocumentContent < BaseRequest
      def initialize(document_id)
        @document_id = document_id
      end

      def name
        "getDocumentContent"
      end

      def endpoint_url(base_url)
        "#{base_url}#{VBMS::ENDPOINTS[:efolder_svc_v1][:read_inline]}"
      end

      def soap_doc
        VBMS::Requests.soap do |xml|
          xml["efol"].getDocumentContent do
            xml["efol"].documentVersionRefID @document_id
          end
        end
      end

      def signed_elements
        [["/soapenv:Envelope/soapenv:Body",
          { soapenv: SoapScum::XMLNamespaces::SOAPENV },
          "Content"]]
      end

      def handle_response(doc)
        el = doc.at_xpath(
          "//efol:getDocumentContentResponse/efol:result", VBMS::XML_NAMESPACES
        )
        construct_response(XMLHelper.convert_to_hash(el.to_xml)[:result])
      end

      private

      def construct_response(result)
        {
          document_id: result[:@document_version_reference_id],
          content: Base64.decode64(result[:bytes])
        }
      end
    end
  end
end
