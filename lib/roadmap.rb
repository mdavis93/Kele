module Roadmap
  def get_roadmaps(id)
    response = self.class.get("/roadmaps/#{id}", headers: { authorization: @auth_token })
    JSON.parse(response.body)
  end

  def get_checkpoint(id)
    response = self.class.get("/checkpoints/#{id}", headers: { authorization: @auth_token })
    JSON.parse(response.body)
  end

  def create_submission(checkpoint, branch, commit_link, comment)
    response = self.class.post('/checkpoint_submissions', headers: {authorization: @auth_token}, body:{
      assignment_branch: branch,
      assignment_commit_link: commit_link,
      checkpoint_id: checkpoint,
      comment: comment,
      enrollment_id: get_me['current_enrollment']['id']
      })
      
      JSON.parse(response.body)
  end
end
