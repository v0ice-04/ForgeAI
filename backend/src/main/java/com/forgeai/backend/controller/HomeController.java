package com.forgeai.backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "ForgeAI Backend is running";
    }

    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}
