package com.voting.online_voting_system.service;

import com.voting.online_voting_system.entity.User;
import com.voting.online_voting_system.entity.RolePermission;
import com.voting.online_voting_system.repository.RolePermissionRepository;
import com.voting.online_voting_system.repository.UserRepository;
import com.voting.online_voting_system.repository.ElectionOfficerAssignmentRepository;
import com.voting.online_voting_system.enums.AssignmentStatus;
import com.voting.online_voting_system.enums.Role;

import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class CustomUserDetailsService
        implements UserDetailsService {

    private final UserRepository userRepository;
    private final RolePermissionRepository rolePermissionRepository;
    private final ElectionOfficerAssignmentRepository assignmentRepository;

    public CustomUserDetailsService(
            UserRepository userRepository,
            RolePermissionRepository rolePermissionRepository,
            ElectionOfficerAssignmentRepository assignmentRepository) {

        this.userRepository = userRepository;
        this.rolePermissionRepository = rolePermissionRepository;
        this.assignmentRepository = assignmentRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email)
            throws UsernameNotFoundException {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "User not found with email: " + email
                        )
                );

        List<SimpleGrantedAuthority> authorities =
                new ArrayList<>();

        authorities.add(
                new SimpleGrantedAuthority(
                        "ROLE_" + user.getRole().name()
                )
        );

        addPermissions(authorities, user.getRole());

        boolean activeAssignment =
                assignmentRepository.findByUserIdAndStatus(
                        user.getId(),
                        AssignmentStatus.ACTIVE
                ).isPresent();

        if (activeAssignment) {
            addPermissions(authorities, Role.ELECTION_OFFICER);
        }

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                authorities
        );
    }

    private void addPermissions(
            List<SimpleGrantedAuthority> authorities,
            Role role) {

        List<RolePermission> rolePermissions =
                rolePermissionRepository.findByRole(role);

        for (RolePermission rolePermission : rolePermissions) {

            authorities.add(
                    new SimpleGrantedAuthority(
                            rolePermission
                                    .getPermission()
                                    .getName()
                    )
            );
        }
    }
}
