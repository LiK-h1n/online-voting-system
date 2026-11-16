package com.voting.online_voting_system.service;

import com.voting.online_voting_system.entity.Election;
import com.voting.online_voting_system.entity.User;
import com.voting.online_voting_system.entity.VotingChallenge;
import com.voting.online_voting_system.repository.VotingChallengeRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
public class OtpService {

    private static final Logger log =
            LoggerFactory.getLogger(OtpService.class);

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int VALID_MINUTES = 5;
    private static final int RESEND_COOLDOWN_SECONDS = 60;

    private final VotingChallengeRepository votingChallengeRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final boolean emailEnabled;

    public OtpService(
            VotingChallengeRepository votingChallengeRepository,
            PasswordEncoder passwordEncoder,
            EmailService emailService,
            @Value("${otp.email.enabled:false}") boolean emailEnabled
    ) {
        this.votingChallengeRepository = votingChallengeRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        this.emailEnabled = emailEnabled;
    }

    public String generateAndSendOtp(
            User user,
            Election election
    ) {

        votingChallengeRepository
                .findTopByUserIdAndElectionIdOrderByCreatedAtDesc(
                        user.getId(),
                        election.getId()
                )
                .filter(previous ->
                        !previous.isUsed()
                                && previous.getCreatedAt().isAfter(
                                LocalDateTime.now().minusSeconds(
                                        RESEND_COOLDOWN_SECONDS
                                )
                        ))
                .ifPresent(previous -> {
                    throw new RuntimeException(
                            "An OTP was sent less than a minute ago. "
                                    + "Please wait before requesting a new one."
                    );
                });

        String otp = String.format(
                "%06d",
                RANDOM.nextInt(1_000_000)
        );

        VotingChallenge challenge = new VotingChallenge();

        challenge.setUser(user);
        challenge.setElection(election);
        challenge.setOtpHash(passwordEncoder.encode(otp));
        challenge.setExpiresAt(
                LocalDateTime.now().plusMinutes(VALID_MINUTES)
        );
        challenge.setAttempts(0);
        challenge.setVerified(false);
        challenge.setUsed(false);
        challenge.setCreatedAt(LocalDateTime.now());

        if (emailEnabled) {

            emailService.sendOtpEmail(
                    user.getEmail(),
                    user.getFirstName(),
                    election.getTitle(),
                    otp,
                    VALID_MINUTES
            );

            votingChallengeRepository.save(challenge);

            return "Code sent successfully to "
                    + maskEmail(user.getEmail());
        }

        votingChallengeRepository.save(challenge);

        log.info(
                "DEV MODE OTP for {} in election {}: {} (expires {})",
                user.getEmail(),
                election.getId(),
                otp,
                challenge.getExpiresAt()
        );

        return "Development mode: code generated successfully "
                + "and printed in the backend console";
    }

    private String maskEmail(String email) {

        int at = email.indexOf('@');

        if (at <= 2) {
            return email;
        }

        return email.substring(0, 2)
                + "*".repeat(at - 2)
                + email.substring(at);
    }
}
