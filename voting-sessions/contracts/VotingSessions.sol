// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract VotingSessions {
    
    struct VotingSession {
        address owner;                     // Créateur de la session
        string title;                      // Titre de la session
        string[] proposals;                // Liste des propositions
        mapping(address => bool) hasVoted; // Pour vérifier si un votant a déjà voté
        mapping(uint => uint) votes;       // Nombre de votes par proposition
        mapping(address => uint) votedProposalIndex; // Index de la proposition votée par chaque votant
        bool isOpen;                       // Indique si la session est encore ouverte
        uint id;                           // Identifiant unique de la session
    }
    
    // Structure allégée pour renvoyer les informations sur une session
    struct SessionInfo {
        uint id;                // Identifiant unique de la session
        address owner;          // Créateur de la session
        string title;           // Titre de la session
        bool isOpen;            // État (ouverte ou fermée)
        string[] proposals;     // Liste des propositions
        bool hasVoted;          // Indique si l'adresse appelante a déjà voté
        int votedProposalIndex; // Index de la proposition choisie par l'adresse appelante (-1 si pas encore voté)
    }
    
    uint public sessionCount;                      // Compteur pour l'identifiant des sessions
    mapping(uint => VotingSession) public sessions; // sessionId => VotingSession
    
    /**
     * @dev Crée une nouvelle session de vote avec un titre et une liste de propositions.
     * @param _title Titre de la session.
     * @param _proposals Tableau contenant les propositions.
     */
    function createSession(string memory _title, string[] memory _proposals) public {
        sessionCount++;
        
        VotingSession storage newSession = sessions[sessionCount];
        newSession.owner = msg.sender;
        newSession.id = sessionCount;
        newSession.isOpen = true;
        newSession.title = _title;
        
        // Copie des propositions
        for (uint i = 0; i < _proposals.length; i++) {
            newSession.proposals.push(_proposals[i]);
        }
    }
    
    /**
     * @dev Permet de voter pour l'une des propositions d'une session donnée (encore ouverte).
     * @param _sessionId Identifiant de la session.
     * @param _proposalIndex Index de la proposition dans le tableau de la session.
     */
    function vote(uint _sessionId, uint _proposalIndex) public {
        VotingSession storage session = sessions[_sessionId];
        
        require(session.isOpen, "La session est close.");
        require(!session.hasVoted[msg.sender], "Vous avez deja vote.");
        require(_proposalIndex < session.proposals.length, "Index de proposition invalide.");
        
        // Marquer que l'adresse a vote
        session.hasVoted[msg.sender] = true;
        // Enregistrer l'index de la proposition choisie
        session.votedProposalIndex[msg.sender] = _proposalIndex;
        // Incrémenter le nombre de votes pour cette proposition
        session.votes[_proposalIndex]++;
    }
    
    /**
     * @dev Permet au propriétaire de la session de la fermer.
     * @param _sessionId Identifiant de la session.
     */
    function closeSession(uint _sessionId) public {
        VotingSession storage session = sessions[_sessionId];
        require(msg.sender == session.owner, "Seul le createur de la session peut la fermer.");
        session.isOpen = false;
    }
    
    /**
     * @dev Retourne la liste des propositions d'une session.
     * @param _sessionId Identifiant de la session.
     */
    function getSessionProposals(uint _sessionId) public view returns (string[] memory) {
        return sessions[_sessionId].proposals;
    }
    
    /**
     * @dev Retourne le nombre de votes pour une proposition donnee d'une session.
     * @param _sessionId Identifiant de la session.
     * @param _proposalIndex Index de la proposition.
     */
    function getProposalVotes(uint _sessionId, uint _proposalIndex) public view returns (uint) {
        return sessions[_sessionId].votes[_proposalIndex];
    }

    /**
     * @dev Retourne l'index de la proposition votée par un utilisateur dans une session.
     *      Retourne -1 si l'utilisateur n'a pas voté.
     * @param _sessionId Identifiant de la session.
     * @param _user Adresse de l'utilisateur.
     */
    function getUserVote(uint _sessionId, address _user) public view returns (int) {
        VotingSession storage session = sessions[_sessionId];
        if (!session.hasVoted[_user]) {
            return -1; // n'a pas voté
        }
        return int(session.votedProposalIndex[_user]);
    }

    /**
     * @dev Retourne la liste de toutes les sessions (avec leurs infos principales),
     *      y compris si l'appelant a déjà voté (hasVoted) et l'index de la proposition choisie (ou -1).
     */
    function getAllSessions() public view returns (SessionInfo[] memory) {
        SessionInfo[] memory allSessions = new SessionInfo[](sessionCount);

        for (uint i = 1; i <= sessionCount; i++) {
            VotingSession storage s = sessions[i];
            
            // Copie du tableau de propositions
            string[] memory props = new string[](s.proposals.length);
            for (uint j = 0; j < s.proposals.length; j++) {
                props[j] = s.proposals[j];
            }
            
            // Récupération de l'index de la proposition votée pour l'adresse appelante
            int votedIndex = -1; 
            if (s.hasVoted[msg.sender]) {
                votedIndex = int(s.votedProposalIndex[msg.sender]);
            }
            
            // Construction de la structure allégée
            SessionInfo memory info = SessionInfo({
                id: s.id,
                owner: s.owner,
                title: s.title,
                isOpen: s.isOpen,
                proposals: props,
                hasVoted: s.hasVoted[msg.sender],
                votedProposalIndex: votedIndex
            });
            
            allSessions[i - 1] = info;
        }
        
        return allSessions;
    }
}
