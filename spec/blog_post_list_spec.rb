require_relative '../lib/blog_post_list'

RSpec.describe BlogPostList do
  describe "#to_html" do
    context "when a blog post is marked as a draft" do
      let!(:draft_blog_post) { { filename: 'my-draft', frontmatter: { 'page_title' => 'My Draft', 'draft' => true } } }
      let!(:blog_post_list_html) { BlogPostList.new([draft_blog_post]).to_html }

      it "still lists the post" do
        expect(blog_post_list_html).to include('My Draft')
      end
    end
  end
end
