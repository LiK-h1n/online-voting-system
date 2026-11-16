package com.voting.online_voting_system.controller;

import com.voting.online_voting_system.dto.OtpRequest;
import com.voting.online_voting_system.dto.OtpVerificationRequest;
import com.voting.online_voting_system.dto.VoteRequest;
import com.voting.online_voting_system.service.VotingService;

import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/votes")
public class VotingController {

    private final VotingService votingService;

    public VotingController(
            VotingService votingService
    ) {
        this.votingService = votingService;
    }

    @PostMapping("/request-otp")
    public ResponseEntity<?> requestOtp(
            @Valid @RequestBody OtpRequest request
    ) {

        try {

            String message =
                    votingService.requestOtp(
                            request.getElectionId()
                    );

            return ResponseEntity.ok(
                    Map.of("message", message)
            );

        } catch (RuntimeException e) {

            return ResponseEntity.badRequest()
                    .body(e.getMessage());
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(
            @Valid @RequestBody
            OtpVerificationRequest request
    ) {

        try {

            votingService.verifyOtp(request);

            return ResponseEntity.ok(
                    "OTP verified successfully"
            );

        } catch (RuntimeException e) {

            return ResponseEntity.badRequest()
                    .body(e.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity<?> castVote(
            @Valid @RequestBody VoteRequest request
    ) {

        try {

            votingService.castVote(request);

            return ResponseEntity.ok(
                    "Vote cast successfully"
            );

        } catch (RuntimeException e) {

            return ResponseEntity.badRequest()
                    .body(e.getMessage());
        }
    }
}
