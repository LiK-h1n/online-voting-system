package com.voting.online_voting_system.config;

import com.voting.online_voting_system.service.ElectionStatusScheduler;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.concurrent.atomic.AtomicLong;

@Component
public class ElectionStatusRefreshInterceptor implements HandlerInterceptor {

    private static final Logger log =
            LoggerFactory.getLogger(ElectionStatusRefreshInterceptor.class);

    private static final long MIN_INTERVAL_MILLIS = 15_000;

    private final ElectionStatusScheduler electionStatusScheduler;
    private final AtomicLong lastRefresh = new AtomicLong(0);

    public ElectionStatusRefreshInterceptor(
            ElectionStatusScheduler electionStatusScheduler) {

        this.electionStatusScheduler = electionStatusScheduler;
    }

    @Override
    public boolean preHandle(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler) {

        long now = System.currentTimeMillis();
        long previous = lastRefresh.get();

        if (now - previous >= MIN_INTERVAL_MILLIS
                && lastRefresh.compareAndSet(previous, now)) {

            try {
                electionStatusScheduler.updateElectionStatuses();
            } catch (Exception e) {
                log.warn("Could not refresh election statuses: {}", e.getMessage());
            }
        }

        return true;
    }
}
