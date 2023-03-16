- rolearn: ${role_arn}
  username: ${k8s_username}
  groups:
%{ for group in k8s_groups ~}
    - ${group}
%{ endfor ~}
