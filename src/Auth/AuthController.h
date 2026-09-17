#pragma once

#include <QtCore/QObject>
#include <QtCore/QString>

// Exposed to QML as a root-context property ("AuthController") from
// QGCCorePlugin::createQmlApplicationEngine(), the same way JoystickManager is.
// Deliberately NOT a QML_SINGLETON: this class lives in a static (NO_PLUGIN) CMake
// module, and nothing else in the app referenced its symbols directly, so the linker
// was dropping its object file from the final exe and the singleton never registered.
class AuthController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool    loggedIn    READ loggedIn    NOTIFY loggedInChanged)
    Q_PROPERTY(QString currentUser READ currentUser NOTIFY loggedInChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)

public:
    explicit AuthController(QObject *parent = nullptr);

    static AuthController *instance();

    bool    loggedIn()    const { return _loggedIn; }
    QString currentUser() const { return _currentUser; }
    QString errorString() const { return _errorString; }

    Q_INVOKABLE bool login(const QString &username, const QString &password);
    Q_INVOKABLE bool registerUser(const QString &username,
                                  const QString &password,
                                  const QString &confirmPassword);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void clearError();

signals:
    void loggedInChanged();
    void errorStringChanged();
    void registrationSucceeded(const QString &username);

private:
    void    _setError(const QString &msg);
    QString _hash(const QString &password) const;
    static QString _normalize(const QString &username);

    bool    _loggedIn = false;
    QString _currentUser;
    QString _errorString;
};