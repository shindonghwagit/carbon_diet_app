package com.example.carbon_backend.repository;

import com.example.carbon_backend.domain.CarbonLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface CarbonLogRepository extends JpaRepository<CarbonLog, Long> {
    List<CarbonLog> findAllByUsername(String username);

    List<CarbonLog> findByUsername(String username);

    @Modifying
    @Transactional
    @Query("UPDATE CarbonLog c SET c.username = :newId WHERE c.username = :currentId")
    void updateUsername(@Param("currentId") String currentId, @Param("newId") String newId);

    @Modifying
    @Transactional
    void deleteAllByUsername(String username);
}