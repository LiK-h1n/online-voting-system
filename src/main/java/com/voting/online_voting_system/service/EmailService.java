package com.voting.online_voting_system.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.util.HtmlUtils;

import java.util.List;
import java.util.Map;

@Service
public class EmailService {

    private static final Logger log =
            LoggerFactory.getLogger(EmailService.class);

    private final RestClient restClient;
    private final String fromAddress;

    public EmailService(
            @Value("${resend.api.key:}") String apiKey,
            @Value("${resend.from:Online Voting System <onboarding@resend.dev>}")
            String fromAddress
    ) {
        this.restClient = RestClient.builder()
                .baseUrl("https://api.resend.com")
                .defaultHeader(
                        HttpHeaders.AUTHORIZATION,
                        "Bearer " + apiKey
                )
                .build();

        this.fromAddress = fromAddress;
    }

    public void sendOtpEmail(
            String to,
            String firstName,
            String electionTitle,
            String otp,
            int validMinutes
    ) {

        String html =
                "<div style=\"font-family:Arial,sans-serif;font-size:15px;color:#222\">"
                        + "<p>Hi " + HtmlUtils.htmlEscape(firstName) + ",</p>"
                        + "<p>Your one-time code to vote in <strong>"
                        + HtmlUtils.htmlEscape(electionTitle)
                        + "</strong> is:</p>"
                        + "<p style=\"font-size:28px;font-weight:bold;letter-spacing:6px\">"
                        + otp
                        + "</p>"
                        + "<p>It expires in " + validMinutes + " minutes "
                        + "and can only be used once.</p>"
                        + "<p>If you didn't request this code, you can ignore this email.</p>"
                        + "</div>";

        Map<String, Object> body = Map.of(
                "from", fromAddress,
                "to", List.of(to),
                "subject", "Your voting code for " + electionTitle,
                "html", html
        );

        try {
            restClient.post()
                    .uri("/emails")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .toBodilessEntity();

        } catch (RestClientException e) {
            log.error(
                    "Failed to send OTP email to {}: {}",
                    to,
                    e.getMessage()
            );

            throw new RuntimeException(
                    "Could not send the OTP email. Please try again."
            );
        }
    }
}
