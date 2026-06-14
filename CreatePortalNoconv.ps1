cd ..                                              # now in the folder holding service-operations-portal
Copy-Item -Recurse service-operations-portal portal-noconv
cd portal-noconv
Remove-Item -Recurse -Force .github                # removes copilot-instructions.md and the chatmodes
Remove-Item -Recurse -Force .git                   # severs git: no branches, no history, just files