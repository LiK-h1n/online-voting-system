package com.voting.online_voting_system.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final ElectionStatusRefreshInterceptor electionStatusRefreshInterceptor;

    public WebConfig(
            ElectionStatusRefreshInterceptor electionStatusRefreshInterceptor) {

        this.electionStatusRefreshInterceptor = electionStatusRefreshInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(electionStatusRefreshInterceptor)
                .addPathPatterns("/api/**");
    }
}
