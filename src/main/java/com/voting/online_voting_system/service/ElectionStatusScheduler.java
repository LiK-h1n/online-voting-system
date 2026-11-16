package com.voting.online_voting_system.service;

import com.voting.online_voting_system.entity.Election;
import com.voting.online_voting_system.enums.AssignmentStatus;
import com.voting.online_voting_system.enums.ElectionStatus;
import com.voting.online_voting_system.repository.ElectionOfficerAssignmentRepository;
import com.voting.online_voting_system.repository.ElectionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class ElectionStatusScheduler {

    private static final Logger log =
            LoggerFactory.getLogger(ElectionStatusScheduler.class);

    private final ElectionRepository electionRepository;
    private final ElectionOfficerAssignmentRepository assignmentRepository;

    public ElectionStatusScheduler(
            ElectionRepository electionRepository,
            ElectionOfficerAssignmentRepository assignmentRepository) {

        this.electionRepository = electionRepository;
        this.assignmentRepository = assignmentRepository;
    }

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void updateElectionStatuses() {

        LocalDateTime now = LocalDateTime.now();

        for (Election election :
                electionRepository.findByStatus(ElectionStatus.UPCOMING)) {

            if (!now.isBefore(election.getStartDate())) {

                election.setStatus(ElectionStatus.ONGOING);
                electionRepository.save(election);

                log.info(
                        "Election {} ({}) is now ONGOING",
                        election.getId(),
                        election.getTitle()
                );
            }
        }

        for (Election election :
                electionRepository.findByStatus(ElectionStatus.ONGOING)) {

            if (!now.isBefore(election.getEndDate())) {

                election.setStatus(ElectionStatus.COMPLETED);
                electionRepository.save(election);

                log.info(
                        "Election {} ({}) is now COMPLETED",
                        election.getId(),
                        election.getTitle()
                );

                assignmentRepository
                        .findByElectionIdAndStatus(
                                election.getId(),
                                AssignmentStatus.ACTIVE
                        )
                        .ifPresent(assignment -> {

                            assignment.setStatus(AssignmentStatus.ENDED);
                            assignmentRepository.save(assignment);

                            log.info(
                                    "EO assignment {} ended with election {}",
                                    assignment.getId(),
                                    election.getId()
                            );
                        });
            }
        }
    }
}
