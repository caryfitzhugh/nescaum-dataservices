require 'test_helper'

class DocumentsControllerTest < NDSTestBase
  def test_documents_index
    get "/documents"
    assert last_response.ok?
    assert_equal json_response, []

    document = create_document!

    get "/documents"
    assert last_response.ok?
    assert_equal json_response.length, 1
    assert_equal json_response.first["title"], "Document"
  end

  def test_document_types_list
    document = create_document!
    get "/documents/types"

    assert last_response.ok?
    assert_equal json_response.length, 1
    assert_equal json_response["types"], ["Article"]
  end

  def test_documents_pagination_query
    create_document!

    get url_for("/documents", page: 2, per_page: 10)
    assert last_response.ok?
    assert_equal json_response.length, 0

    get url_for("/documents", page: 1, per_page: 10)
    assert last_response.ok?
    assert_equal json_response.length, 1

    get url_for("/documents")
    assert last_response.ok?
    assert_equal json_response.length, 1
  end

  def test_documents_create_inaccessible
    create_document!
    post_document(title: "Creating", type: "Article", sector_id: Models::Sector.first.id)
    assert !last_response.ok?
  end

  def test_documents_create
    login_curator!
    create_document!
    args = {title: "Creating", type: "Article", sector_id: Models::Sector.first.id}
    post_document(args)
    assert last_response.ok?

    # No Title restriction
    post_document(args)
    assert last_response.ok?
  end

  def test_documents_delete_inaccessible
    delete_document(100)
    assert_equal last_response.status, 403
  end

 def test_documents_delete
   login_curator!
   delete_document(100)
   assert_equal last_response.status, 404, last_response.body

   document = create_document!
   delete_document(document.id)
   assert last_response.ok?
 end

  private

  def create_document!(params = {})
    sector = Models::Sector.create(name: "sector")
    document = Models::Document.create({title: "Document", sector_id: sector.id, type: "Article"}.merge(params))
  end

  def delete_document(id)
    delete url_for("/documents/#{id}")
  end

  def post_document(attrs)
    post_json(url_for("/documents"), {"document": attrs})
  end
end
