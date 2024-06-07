require 'json'

control "flux-system" do
  title "flux-system"
  tag "spec"

  namespace = "flux-system"
  node_group = input('management_node_group_name')
  toleration_value = input('management_node_group_role')

  describe 'pods' do
    pods = JSON.parse(`kubectl get pods -n #{namespace} -o json`)
    pods.dig('items').each do |pod|
      describe pod.dig('metadata', 'name') do
        it "should run on a #{toleration_value} node" do
          expect(pod).to run_on_node_group("#{node_group}")
        end
      end
    end
    it "should be running on different nodes" do
      expect(pods.dig('items').map { |x| x.dig('spec', 'nodeName') }).to be_unique
    end
  end
end
