package com.testmobile.backend.repository;

import com.testmobile.backend.model.Gee;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GeeRepository extends JpaRepository<Gee, Long> {
}
