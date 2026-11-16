package com.voting.online_voting_system.controller;

import com.voting.online_voting_system.entity.Notification;
import com.voting.online_voting_system.entity.User;
import com.voting.online_voting_system.repository.NotificationRepository;
import com.voting.online_voting_system.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationController(
            NotificationRepository notificationRepository,
            UserRepository userRepository) {

        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    private User currentUser(Authentication authentication) {
        return userRepository
                .findByEmail(authentication.getName())
                .orElseThrow(() ->
                        new RuntimeException("User not found"));
    }

    @GetMapping("/my")
    public ResponseEntity<List<Notification>> getMyNotifications(
            Authentication authentication) {

        User user = currentUser(authentication);

        return ResponseEntity.ok(
                notificationRepository
                        .findByUserIdOrderByCreatedAtDesc(user.getId())
        );
    }

    @GetMapping("/my/unread")
    public ResponseEntity<List<Notification>> getMyUnreadNotifications(
            Authentication authentication) {

        User user = currentUser(authentication);

        return ResponseEntity.ok(
                notificationRepository
                        .findByUserIdAndIsReadFalseOrderByCreatedAtDesc(
                                user.getId()
                        )
        );
    }

    @PutMapping("/{notificationId}/read")
    public ResponseEntity<?> markAsRead(
            @PathVariable Long notificationId,
            Authentication authentication) {

        User user = currentUser(authentication);

        Notification notification =
                notificationRepository.findById(notificationId)
                        .orElse(null);

        if (notification == null) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body("Notification not found");
        }

        if (!notification.getUser().getId().equals(user.getId())) {
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body("You can only update your own notifications");
        }

        notification.setRead(true);

        return ResponseEntity.ok(
                notificationRepository.save(notification)
        );
    }
}