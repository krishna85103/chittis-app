package com.testmobile.backend;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Component
public class HttpLoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        ContentCachingRequestWrapper wrappedRequest =
                new ContentCachingRequestWrapper(request);

        ContentCachingResponseWrapper wrappedResponse =
                new ContentCachingResponseWrapper(response);

        long startTime = System.currentTimeMillis();

        try {
            filterChain.doFilter(wrappedRequest, wrappedResponse);
        } finally {

            long duration =
                    System.currentTimeMillis() - startTime;

            String requestBody =
                    new String(
                            wrappedRequest.getContentAsByteArray(),
                            StandardCharsets.UTF_8
                    );

            String responseBody =
                    new String(
                            wrappedResponse.getContentAsByteArray(),
                            StandardCharsets.UTF_8
                    );

            System.out.println();
            System.out.println("========== HTTP REQUEST ==========");
            System.out.println("Method : " + request.getMethod());
            System.out.println("URI    : " + request.getRequestURI());

            if (request.getQueryString() != null) {
                System.out.println(
                        "Query  : " + request.getQueryString()
                );
            }

            System.out.println("Body   : " + maskSensitiveData(requestBody));
            System.out.println("==================================");

            System.out.println();
            System.out.println("========= HTTP RESPONSE ==========");
            System.out.println("Status : " + response.getStatus());
            System.out.println("Time   : " + duration + " ms");
            System.out.println("Body   : " + maskSensitiveData(responseBody));
            System.out.println("==================================");
            System.out.println();

            wrappedResponse.copyBodyToResponse();
        }
    }

    private String maskSensitiveData(String body) {

        if (body == null || body.isBlank()) {
            return "(empty)";
        }

        // Mask JSON password values
        return body.replaceAll(
                "(\"password\"\\s*:\\s*\")[^\"]*(\")",
                "$1***$2"
        );
    }
}
